function [ m_final , l ] = hex_to_binary( hex_str )

    n = length(hex_str); 
    bin_str = zeros(n, 4); % hex 2 binary -> always 4 bits
    
    for h = 1 : n
        bin_str(h,:) = [h2b(hex_str(h))];
    end
    m_final=reshape(bin_str',1,n*4);
    l = n*4;

end

