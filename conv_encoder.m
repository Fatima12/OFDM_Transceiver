function [ ReSh2 ] = conv_encoder( scrambledData )

    g{1} = [1 0 1 1 0 1 1];     % Impulse Responses _ 1
    g{2} = [1 1 1 1 0 0 1];  
    n = 2;                      % depends on rate
    
    for i = 1:n    %encoding 1/2 rate conv code
        y{i} = mod(conv(scrambledData,g{i}),2);
    end
    y1=[y{1};y{2}];
    ReSh2=reshape(y1,1,n*(length(y1)));
    ReSh2=ReSh2(1:length(ReSh2)-12);            % flushing bits removed

end

