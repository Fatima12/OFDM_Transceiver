function b = h2b(h)
switch h
    case {'0'}
        b = [0 0 0 0];
    case {'1'}
        b = [1 0 0 0];
    case {'2'}
        b = [0 1 0 0];
    case {'3'}
        b = [1 1 0 0];
    case {'4'}
        b = [0 0 1 0];
    case {'5'}
        b = [1 0 1 0];
    case {'6'}
        b = [0 1 1 0];
    case {'7'}
        b = [1 1 1 0];
    case {'8'}
        b = [0 0 0 1];
    case {'9'}
        b = [1 0 0 1];
    case {'A', 'a'}
        b = [0 1 0 1];
    case {'B', 'b'}
        b = [1 1 0 1];
    case {'C', 'c'}
        b = [0 0 1 1];
    case {'D', 'd'}
        b = [1 0 1 1];
    case {'E', 'e'}
        b = [0 1 1 1];
    case {'F', 'f'}
        b = [1 1 1 1];
end