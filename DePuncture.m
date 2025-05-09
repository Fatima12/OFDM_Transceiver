function [ code ] = DePuncture( data1 , numBits_PerPacket , puncturingPattern1 , puncturingBits )
    
    first_resh=reshape(data1 , (puncturingPattern1-numel(puncturingBits)) , length(data1)/(puncturingPattern1-numel(puncturingBits)) );
    
    out = zeros(puncturingPattern1 , numBits_PerPacket/( puncturingPattern1 - numel(puncturingBits) ) );
    out( puncturingBits , : ) = inf;
    out( out == 0 ) = first_resh;
    
    code = reshape(out , 1 , numBits_PerPacket*puncturingPattern1/( puncturingPattern1 - numel(puncturingBits) ) );

end

