function [ output ] = taking_iFFT2( data , n , nFFTSize )

    output = complex(zeros(1,nFFTSize));
    for i = 1:numel(n)
        output = output + data(i).*exp(1i*2*pi*(n(i))/nFFTSize.*(0:nFFTSize-1) );
    end
    output = output / nFFTSize;

end

