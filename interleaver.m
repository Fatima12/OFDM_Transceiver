function [ secondPermu1 ] = interleaver( M , turn1 )

    Ncbs=log2(M)*48;        % total bits in one ofdm synbol
    k=0:Ncbs-1;             %
    Nb=log2(M);             % bps
    ii=0:Ncbs-1;                 %
    
    i=(Ncbs/16)*(mod(k,16))+floor(k/16);    %first permutatiuon
    s=max(Nb/2,1);
    t=ii+Ncbs-floor(16*ii/Ncbs);
    j=s*floor(ii/s)+mod(t,s);
    
    for ind=1:Ncbs
        firstPermu(i(ind)+1)=turn1(k(ind)+1);
    end
    
    for ind=1:Ncbs
        secondPermu1(j(ind)+1)=firstPermu(k(ind)+1);
    end


end

