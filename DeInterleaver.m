function [ secondPermu11 ] = DeInterleaver( M , rcvd1 )

    Ncbs=log2(M)*48;        % total bits in one ofdm synbol
    j_j=0:Ncbs-1;
    Nb=log2(M);
    ii=0:Ncbs-1;
    
    ss=max(Nb/2,1);
    i_i=ss*floor(j_j/ss)+mod(j_j+floor(16*j_j/Ncbs),ss);
    k_k=16*ii-(Ncbs-1)*floor(16*ii/Ncbs);
    
    
    firstPermu=Inf*ones(1,Ncbs);
    secondPermu11=Inf*ones(1,Ncbs);
    for ind=1:Ncbs
        firstPermu(i_i(ind)+1)=rcvd1(j_j(ind)+1);
    end
    
    for ind=1:Ncbs
        secondPermu11(k_k(ind)+1)=firstPermu(j_j(ind)+1);
    end



end

