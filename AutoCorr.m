function [ b, final_array] = AutoCorr( Yr,PreambleLength )

    offset=(PreambleLength);
    
    final_array=zeros(1,length(Yr)-2*(PreambleLength)+1);
    
    for j=0:length(Yr)-2*(PreambleLength)
    
          final_array(j+1) = sum( Yr(j+1 : j + offset).*conj(Yr(j+1+offset: j + offset+offset )) ) / sum( Yr(j+1 : j + offset).*conj( Yr(j+1 : j + offset) ) );
    end
     
    [a,b] = max(abs(final_array));

end

