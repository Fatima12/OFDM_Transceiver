function [ CompletePreamble_FreqOffset ] = InsertFreqOffset( CompletePreamble, FreqOffset  )

    n = 1:numel(CompletePreamble);
    CompletePreamble_FreqOffset=CompletePreamble.*exp(1i*2*pi*FreqOffset.*n);

end

