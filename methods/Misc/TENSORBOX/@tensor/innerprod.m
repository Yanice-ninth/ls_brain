function res = innerprod(X,Y)
%INNERPROD Efficient inner product with a tensor.
%
%   R = INNERPROD(X,Y) efficiently computes the inner product between
%   two tensors X and Y.  If Y is a tensor, then inner product is
%   computed directly.  Otherwise, the inner product method for
%   that type of tensor is called.
%
%   See also TENSOR, SPTENSOR/INNERPROD, KTENSOR/INNERPROD, TTENSOR/INNERPROD
%
%MATLAB Tensor Toolbox.
%Copyright 2010, Sandia Corporation. 

% This is the MATLAB Tensor Toolbox by Brett Bader and Tamara Kolda. 
% http://csmr.ca.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2010) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in tensor_toolbox/LICENSE.txt
% $Id: innerprod.m,v 1.10 2010/03/19 23:46:30 tgkolda Exp $

% X is a tensor
switch class(Y)
 
  case {'tensor'}
    % No need for same size check because it is implicit in the inner
    % product below. 
    x = reshape(X.data, 1, numel(X.data));
    y = reshape(Y.data, numel(Y.data), 1);
    res = x*conj(y); % fixed for complex-valued tensor
    
  case {'sptensor','ktensor','ttensor'}
    % Reverse arguments to call specialized code
    res = conj(innerprod(Y,X));   % Fixed for complex-valued tensor
 
  otherwise
    disp(['Inner product not available for class ' class(Y)]);

end

return;
