function [ scrambledData ] = scrambler( m_final , bitLength , initial_state)


    n = bitLength;
    Sc_final = zeros(1,n);
    poly = initial_state;
    
    for i = 1:n
        Sc_final(i) = mod(poly(1) + poly(4) , 2);
        poly = [poly(2:end) Sc_final(i)];
    end
    
    scrambledData=mod(Sc_final+m_final,2);

end

