function [res]=gemi_mcl( source, target)

members=properties(target);
idx=strmatch('all',members);
members(idx)=[];
for i=1:numel(members)
    if ( strcmp( class( target.( members{ i } ) ) , 'Subject' ) && ~strcmp( members{ i } , 'all' ) )
        [rated60150(i,1) rated60150(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [15 25 35 45] , 'target_label' ,  1 );
        [rated60135(i,1) rated60135(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [16 26 36 46] , 'target_label' ,  1 );
        [rated60120(i,1) rated60120(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [17 27 37 47] , 'target_label' ,  1 );
        [rates60(i,1) rates60(i,2)]  = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [50 51 52 53] , 'target_label' , -1 );
        [rates150(i,1) rates150(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [14 24 34 44] , 'target_label' , -1 );
        [rates135(i,1) rates135(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [13 23 33 43] , 'target_label' , -1 );
        [rates120(i,1) rates120(i,2)] = source.default.apply_classifier( target.(  members{i} ).default , 'name' , 'groupL' , 'target_markers'  , [12 22 32 42] , 'target_label' , -1 );
    end
end

res.avg=[sum(rated60150(:,1)'*rated60150(:,2))/sum(rated60150(:,2))... 
    sum(rated60135(:,1)'*rated60135(:,2))/sum(rated60135(:,2))...
    sum(rated60120(:,1)'*rated60120(:,2))/sum(rated60120(:,2))...
    sum(rates60(:,1)'*rates60(:,2))/sum(rates60(:,2))...
    sum(rates150(:,1)'*rates150(:,2))/sum(rates150(:,2))...
    sum(rates135(:,1)'*rates135(:,2))/sum(rates135(:,2))...
    sum(rates120(:,1)'*rates120(:,2))/sum(rates120(:,2)) ];

res.rated60150=rated60150;
res.rated60135=rated60135;
res.rated60120=rated60120;
res.rates60=rates60;
res.rates150=rates150;
res.rates135=rates135;
res.rates120=rates120;

res.perf(1)= (sum(prod(rated60150'))+sum(prod(rates60')))/(sum(rated60150(:,2))+sum(rates60(:,2)));
res.perf(2)= (sum(prod(rated60135'))+sum(prod(rates60')))/(sum(rated60135(:,2))+sum(rates60(:,2)));
res.perf(3)= (sum(prod(rated60120'))+sum(prod(rates60')))/(sum(rated60120(:,2))+sum(rates60(:,2)));
res.perf(4)= (sum(prod(rated60150'))+sum(prod(rates150')))/(sum(rated60150(:,2))+sum(rates150(:,2)));
res.perf(5)= (sum(prod(rated60135'))+sum(prod(rates135')))/(sum(rated60135(:,2))+sum(rates135(:,2)));
res.perf(6)= (sum(prod(rated60120'))+sum(prod(rates120')))/(sum(rated60120(:,2))+sum(rates120(:,2)));


end


