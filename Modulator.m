function [ modData ] = Modulator( M , data )
% assunming data is in multiples of bits per symbol

    factor = [1 1/sqrt(2) 0 1/sqrt(10) 0 1/sqrt(42)];
    
    hModulator = comm.RectangularQAMModulator(M,'BitInput',true);
    
    modData = factor(log2(M)).*step(hModulator, data)';        % conjugate induction to match ieee to matlab


end

