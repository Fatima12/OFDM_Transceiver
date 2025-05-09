function [ Freq_done ] = Freq_compensation( stream, Freq_offset )

    n=1:numel(stream);
    Freq_done=stream.*exp(-1i*2*pi.*n*Freq_offset);

end

