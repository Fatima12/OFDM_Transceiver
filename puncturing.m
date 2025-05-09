function [ code ] = puncturing( Resh2, numPackets , numBits_PerPacket , puncturingPattern1 , puncturingBits)% 6, [4 5]
%% puncturingPattern1 is the number of slices in whihc data is to be divided
%% puncturingBits contains whcih bits are to be discarded


    rcvdData = reshape(Resh2,length(Resh2)/numPackets,numPackets);
    rcvdData = rcvdData.';
    code = zeros(numPackets , numBits_PerPacket);
    
    
    for j=1:numPackets
        
        data1=rcvdData(j,:);
        
        first_resh=reshape(data1 , puncturingPattern1 , length(data1)/puncturingPattern1 );
        
        
        pos = 1;
        out = [];
        for i = 1:puncturingPattern1
            if (~sum( (puncturingBits == i) , 1)  )             
                out(pos,:) = first_resh(i,:);
                pos = pos+1;
            end
        end
        [a,b]=size(out);
        data=reshape(out,1,a*b);
      
        code(j,:)=data; 
          
    
    end


end

