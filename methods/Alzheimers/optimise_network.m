function [ W , metric , iter] = optimise_network(W,metric_type,target_value,varargin)

opts = struct ( 'modules',[],'structure', [] ) ;
[ opts  ] = parseOpts( opts , varargin );
opts2var

n=size(W,1);
O=ones(n);
H=O-eye(n);

Winit=W;
l=1;
penalty=inf;
iter=1;
dW=Inf;
max_iter=10000;
%while penalty>0.001 | iter>10000
while norm(dW)>0.000001 && iter<max_iter
    
    
    
    [penalty,tmp]=network_penalty_wu(W,metric_type,target_value,'modules',modules);
    metric(iter)=tmp;
    dW=l*(abs(penalty))*sign(penalty)*network_gradient_wu(W,metric_type,...
        'modules',modules,'structure',structure);
    
    W = W - dW;
    W(W<0)=0;
    W(W>1)=1;
    %     W=W/max(max(W));
    iter=iter+1;
    
end

% W=W/max(max(W));

end