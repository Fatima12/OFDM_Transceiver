function [ b ,corr_array , num_crossCorr] = CrossCorr( Yr, Preamble_RRC )

    num_crossCorr = length(Yr)-length(Preamble_RRC)+1;
    corr_array=zeros(1,num_crossCorr);
    offset = numel(Preamble_RRC);
    for i=1:num_crossCorr
    
        corr_array(i) = sum( Yr(i : i + offset - 1 ).*conj( Preamble_RRC ) ) / sum( Yr(i : i + offset - 1 ).*conj( Yr(i : i + offset - 1 ) ) ) ;
    
    end
    [a,b]=max(abs(corr_array));

end

