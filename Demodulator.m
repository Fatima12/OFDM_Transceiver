function [ RxBits ] = Demodulator( M , RxData )

    factor = [1 1/sqrt(2) 0 1/sqrt(10) 0 1/sqrt(42)];
    
    hDemod = comm.RectangularQAMDemodulator(M,'BitOutput',true);
    
    RxBits = step(hDemod, RxData./factor(log2(M)));  
    RxBits = RxBits.';

end

