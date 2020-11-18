function code = ca_code(prn)
% function code = ca_code(prn)
% This function returns the C/A code sequence (1023 bytes long,
% represented as 1023x1 vector of integers with values of +/- 1

% Error messages

if nargin~=1
   error('insufficient number of input argumnets')
end
if prn<0 | prn > 37
   error('invalid prn: must be between 1 and 37')
end

g2shift_vector=[5 6 7 8 17 18 139 140 141 251 252 254 255 256 257 258 ...
   469 470 471 472 473 474 509 512 513 514 515 516 859 860 861 862 ...
   863 950 947 948 950];

g2shift=g2shift_vector(prn);


%
% Generate G1 code
%

% load shift regeister

for i=1:10,
   reg(i) = -1;
end

% Generate code

for i=1:1023,
   g1(i) = reg(10);
   save1 = reg(3)*reg(10);
   for j=9:-1:1,
      reg(j+1)=reg(j);
   end
   reg(1)=save1;
end

%
% Generate G2 code
%

% load shift regeister

for i=1:10,
   reg(i) = -1;
end

% Generate code

for i=1:1023,
   g2(i) = reg(10);
   save2 = reg(2)*reg(3)*reg(6)*reg(8)*reg(9)*reg(10);
   for j=9:-1:1,
      reg(j+1)=reg(j);
   end
   reg(1)=save2;
end

% Shift the G2 code

for i=1:1023,
   k = i+g2shift;
   if k > 1023,
     k = k-1023;
   end
   g2tmp(k) = g2(i);
end

g2 = g2tmp;

% Form the C/A code by multiplying G1 and G2

code = g1.*g2;
