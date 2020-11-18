function signal = DataReader(fileIn, duration)

%%% fileIN is the path to access the file that contains the data.
%%% Duration is the number of samples to read.

% Opening the file
fidIn = fopen(fileIn,'rb');

% Identifier file = -1 -> cant read the file
if (fidIn == -1) 
    error(sprintf('Erreur ouverture %s',fileIn));
end

[signal,nB] = fread(fidIn,duration,'bit2');

% if (nB ~= duration)
%     error(sprintf('Erreur lecture %s',fileIn));
% end

% Closing the file
fclose(fidIn);
