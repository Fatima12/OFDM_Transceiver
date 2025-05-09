clc;
clear all;
close all;

%% variables
nFFTSize = 64;
M = 16;
bps = log2(M);
numSubcarrier = 48;
codingRate = 2;             % FIXED - dont change
convCoder_Memory = 6;
puncturingPattern = 6;
puncturingBits = [4 5];
puncturingRate = (puncturingPattern - numel(puncturingBits) )/puncturingPattern;
CP_length=16;
shortPreamble_length = 16;
longPreamble_length = 64;

%% data generation and length correction
hex_str = '0000402000e2000680dc736a00026d10c31f000680dab3fa0000a4f697c2022627967686470237071627b602f6660246966796e6964797c2a0441657768647562702f6660254c697379657d6c2a064962756d296e637962756460277560247275616ad7599de';
[bitStream,bitLength] = hex_to_binary(hex_str);

bitStream = [bitStream zeros(1 ,convCoder_Memory)];        % zeros for conv coder
bitLength = bitLength + convCoder_Memory;

numCodedBits = bitLength * codingRate * puncturingRate;
numBits_PerPacket = numSubcarrier * bps; 
numPackets = ceil((numCodedBits) / bps / numSubcarrier );
numBits_neededCoded = numPackets*numBits_PerPacket - numCodedBits;
numBits_neededUnCoded = (numBits_neededCoded / codingRate / puncturingRate);

bitStream = [bitStream zeros(1 , numBits_neededUnCoded)];   % zeros for integer number of packets
bitLength = bitLength + numBits_neededUnCoded;

%% Preamble Generation
shortPreamble = short_Training_Sequence(nFFTSize);
longPreamble = long_Training_Sequence(nFFTSize);
longPreamble(1) = longPreamble(1) + shortPreamble(1); 
completePreamble = [shortPreamble longPreamble];

%% Scrambling on Data
scrambledData = scrambler(bitStream , bitLength , [1 0 1 1 1 0 1]);
scrambledData(bitLength - convCoder_Memory - numBits_neededUnCoded + 1 : bitLength - numBits_neededUnCoded) = 0;

%% Encoding
EncodedData = conv_encoder(scrambledData);

%% Puncturing
PuncturedData = puncturing(EncodedData , numPackets , numBits_PerPacket , puncturingPattern , puncturingBits);

%% interleaving
Packet=zeros(size(PuncturedData));
for NumOfPackets = 1:numPackets
    Packet(NumOfPackets,:) = interleaver(M , PuncturedData(NumOfPackets,:));
end

%% Modulation
ModData = zeros(numPackets , numSubcarrier);
for NumOfPackets = 1:numPackets
    ModData(NumOfPackets,:) = Modulator(M , Packet(NumOfPackets,:).' );
end

%% FFT of data and Pilots Adding
pilotSequence = scrambler(zeros(1,numPackets+10) , numPackets + 10 , [1 1 1 1 1 1 1]);
pilotSequence(pilotSequence == 0) = -1;
pilotSequence = pilotSequence*-1;

completeData = complex(zeros(numPackets , numSubcarrier+5+11));
fftData = complex(zeros(numPackets , numSubcarrier+5+11));

n = -32:31;
for NumOfPackets=1:numPackets
    completeData(NumOfPackets , :) = p_insertion(ModData(NumOfPackets , :) , pilotSequence(NumOfPackets + 1) );
    fftData(NumOfPackets , :) = taking_iFFT2(completeData(NumOfPackets,:) , n , nFFTSize);
end


%% CP
CP_fftData = [fftData(:, end - CP_length + 1:end) fftData];

%% Channel- Freq Offset
CompletePreamble_FreqOffset = InsertFreqOffset(completePreamble,0.003);

%% Packet Detection via ACORR
[CompletePreamble_PacketStart_Esti,AutoCorr_array] = AutoCorr(CompletePreamble_FreqOffset , 16);
AutoCorr_array = abs(AutoCorr_array);
plot(AutoCorr_array);
threshold = 0.8;
shortPreamble_Est = find(AutoCorr_array > threshold);

%% Freq Offset Est
angle_array = conj(CompletePreamble_FreqOffset( ceil(numel(shortPreamble_Est)/2) - shortPreamble_length : ceil(numel(shortPreamble_Est)/2) - 1 )) ... 
    .* CompletePreamble_FreqOffset( ceil(numel(shortPreamble_Est)/2)  : ceil(numel(shortPreamble_Est)/2) + shortPreamble_length - 1 ) ;
CoarseFreq_estimate = angle(sum(angle_array)) / (2*pi*shortPreamble_length);

%% Freq Offset compensaate
CompletePreamble_Position_Extract = CompletePreamble_FreqOffset(shortPreamble_Est(1):end);
CompletePreamble_FreqOffset_Compensated = Freq_compensation(CompletePreamble_Position_Extract, CoarseFreq_estimate);

%% Precise Timing Estimation 

ExtractedLongPreamble = longPreamble(1:64);
[Fine_Position_Estimate, CrossCorr_array,num_crossCorr] = CrossCorr(CompletePreamble_FreqOffset_Compensated , ExtractedLongPreamble);
CrossCorr_array = abs(CrossCorr_array);
figure()
plot(CrossCorr_array);
[maxValue , maxPos] = max(CrossCorr_array);
if ( (maxPos + longPreamble_length) < num_crossCorr) 
    if ( CrossCorr_array(maxPos + longPreamble_length) > 0.7*maxValue ) 
        maxPos = maxPos + longPreamble_length;
    end
end
dataStart = maxPos + 96;

RxLongPreamble = CompletePreamble_FreqOffset_Compensated(maxPos : maxPos + longPreamble_length -1 );

%% RECEIVER
%% FFT
CP_offset = 0;              
RxReceived = CP_fftData;
RxComplete = RxReceived(:,17-CP_offset : end-CP_offset);%fftData;
ifftData = complex(zeros(numPackets , numSubcarrier+5+11));

for NumOfPackets=1:numPackets
    ifftData(NumOfPackets , :) = fftshift(fft(RxComplete(NumOfPackets,:) , nFFTSize).*exp(1i*(2*pi/64)*CP_offset.*(0:63)) );
end

%% Pilot and data separation
pilots = complex(zeros(numPackets , 4));
RxData = complex(zeros(numPackets , numSubcarrier));
for NumOfPackets=1:numPackets
    [ RxData(NumOfPackets,:) , pilots(NumOfPackets,:) ] = p_removal( ifftData(NumOfPackets,:) );
end

%% DeModulator
DeModData = zeros(numPackets , bps*numSubcarrier);
for NumOfPackets = 1:numPackets
    DeModData(NumOfPackets,:) = Demodulator(M , RxData(NumOfPackets,:)' );      % conj for 
end

%% Deinterleaver
DeInterleavedData = zeros(numPackets , bps*numSubcarrier);
for NumOfPackets = 1:numPackets
    DeInterleavedData(NumOfPackets,:) = DeInterleaver(M , DeModData(NumOfPackets,:) );
end

%% De-puncturing
DePuncturedData = zeros(numPackets , bps*numSubcarrier*puncturingPattern/(puncturingPattern -  numel(puncturingBits)) );
for NumOfPackets = 1:numPackets
    DePuncturedData(NumOfPackets,:) = DePuncture( DeInterleavedData(NumOfPackets,:) , numBits_PerPacket , puncturingPattern , puncturingBits );
end
DePuncturedData = DePuncturedData.';
DePuncturedData = reshape(DePuncturedData , 1 , numPackets*numBits_PerPacket*puncturingPattern/( puncturingPattern-numel(puncturingBits) ) ); 

%% Decoding
DeCodedData = zeros(1 , numPackets*bps*numSubcarrier*puncturingPattern/(puncturingPattern -  numel(puncturingBits))/codingRate );
DeCodedData = ConvDecoding( DePuncturedData , convCoder_Memory );

%% Descrambling
DeScrambledData = zeros(1 , numPackets*bps*numSubcarrier*puncturingPattern/(puncturingPattern -  numel(puncturingBits))/codingRate );
DeScrambledData =  scrambler(DeCodedData , numel(DeCodedData) , [1 0 1 1 1 0 1]);

%%


