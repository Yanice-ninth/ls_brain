mtype=[];
mtype{1}='trans';
mtype{2}='clust';
mtype{3}='deg';
clear E

for k=1:numel(mtype)
    
    M{k}=ls_network_metric(W1,mtype{k});
    Mr{k}=rand(1,numel(M{k}));    
end

tst_idx=50;
for trial=51:size(We,3)
    
    Wd = optimise_network_multi(We(:,:,trial),mtype,M');
    Wr = optimise_network_multi(We(:,:,trial),mtype,Mr');
    E(trial-tst_idx,:)=[norm(Wd-W2,'fro') norm(Wr-W2,'fro') norm(We(:,:,trial)-W2,'fro')];
    RES{trial-tst_idx}={Wd Wr We(:,:,trial)};
    
end
