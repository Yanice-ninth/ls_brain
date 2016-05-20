function [dm] = multitrial_performance( dv_all , Yall, n_con_ex, positive_class, method , max_tr_per_seq, min_tr_per_seq,pos_sel,neg_sel,bias_mod)

% INPUTS
% function [dm] = multitrial_performance( dv_all , Yall, n_con_ex, positive_class,
%                 method , max_tr_per_seq, min_tr_per_seq,pos_sel,neg_sel,bias_mod)
% dv_all            - classifier predictions (trials x subproblem)
% Yall              - labels (trials x subproblem)
% n_con_ex          - number of consecutive examples (i.e. sequence length)
% positive_class    - identifier for the positive class (-1, or +1) 
% method            - which trial combination method to use (e.g. simple averaging
% max_tr_per_seq    - maximum number of trials to combine within a
%                     sequence(should be less than n_con_ex)
% min_tr_per_seq    - minimum number of trials to combine within a
%                     sequence(>0!!!!)
% pos_sel           - subselect trials from the positive class
% neg_sel           - subselect trials from the negative class
% bias_mod          - range of biases to search for

% OUTPUTS
% fpr               - False positive rate (combined trials x bias value)
% tpr               - True positive rate  (combined trials x bias_value)
% perf              - Classification performance (combined_trials x
%                     bias_value)

pc=positive_class;

for sp=1:size(Yall,2)
    
    if (sp<=size(Yall,2))
        spdv=sp;
        spY=sp;
    else
        spdv=mod(sp+1,size(Yall,2))+1;
        spY=mod(sp,size(Yall,2))+1;
    end
    
    Y=Yall(:,spY);
  
    dv = dv_all( Y ~= 0 ) ;
    dv = dv*pc;
    
    Y = Y( Y ~= 0 ) ;
    
    i_nclass    =  Y ==  -1*pc ;
    i_pclass    =  Y == pc ;
    
    Y_nclass    =  Y( i_nclass ) ;
    Y_pclass    =  Y( i_pclass ) ;
    
    dv_positive =  dv( i_pclass ); %%%% add pc and for later for >0 <0!!!!!
    dv_negative =  dv( i_nclass );
    
    if pos_sel==0
        pos_sel=1:numel(dv_positive);
    end
    if neg_sel==0
        neg_sel=1:numel(dv_negative);
    end
    
    dv_positive=dv_positive(pos_sel);
    dv_negative=dv_negative(neg_sel);
    dv_positive(isnan(dv_positive))=0;
    dv_negative(isnan(dv_negative))=0;
    fpr.vanilla = sum( dv_negative( : ) > 0 ) / numel( dv_negative( : ) ) ;
    tpr.vanilla = sum( dv_positive( : ) > 0 ) / numel( dv_positive( : ) ) ;
    
    if (isempty(bias_mod))
        bias_mod=-10:10/500:10;
    end
    
    if (strcmp(method,'sav'))
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex_p=numel(dv_positive);%%careful
            n_con_ex_n=numel(dv_negative);%%careful
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
            
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear sav_dv_positive sav_dv_negative transition_dv_positive
            
            for j=1:numel(bias_mod)
                
                for i=1:columns_positive
                    
                    sav_dv_positive( : , i ) = filter( 1 / tr_per_seq*ones( 1 , tr_per_seq ) , 1 , dv_positive( : , i ) + bias_mod(j) ) ;
                    
                end
                for i=1:columns_negative
                    
                    sav_dv_negative( : , i ) = filter( 1 / tr_per_seq*ones( 1 , tr_per_seq ) , 1 , dv_negative( : , i ) + bias_mod(j) ) ;
                    
                end
                                
                dv_neg = sav_dv_negative( tr_per_seq : end , : ) ;
                dv_pos = sav_dv_positive( tr_per_seq : end , : ) ;
                fpr.sav( tr_per_seq , j) = sum( dv_neg( : ) > 0 ) / numel( dv_neg( : ) ) ;
                dv_neg=dv_neg(:);              
                tpr.sav( tr_per_seq , j ) = sum( dv_pos( : ) > 0 ) / numel( dv_pos( : ) ) ;                                
                fpr.dv_neg{tr_per_seq,j}=sav_dv_negative(tr_per_seq:end);
                tpr.dv_pos{tr_per_seq,j}=sav_dv_positive(tr_per_seq:end);
                perf.sav(tr_per_seq,j) = (1-fpr.sav( tr_per_seq , j) + tpr.sav( tr_per_seq , j ) ) /2;
          
            end
            
        end
    elseif (strcmp(method,'sav_switch'))
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv)/2;%%careful
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear sav_dv_positive sav_dv_negative transition_dv_positive
            
            for j=1:numel(bias_mod)
                
                for i=1:columns_positive
                    
                    sav_dv_positive( : , i ) = filter( 1 / tr_per_seq*ones( 1 , tr_per_seq ) , 1 ,...
                        [dv_negative( : , i )' dv_positive( : , i )'] + bias_mod(j) )' ;
                    
                end
                
                dv_pos = sav_dv_positive( numel( dv_negative( : , i ) ) + 1 : end , : ) ;
                tpr.sav{ tr_per_seq , j } = sum( dv_pos > 0 , 2 ) / size( dv_pos , 2 ) ;
                
            end
            
        end
    elseif (strcmp(method,'nrow_switch'))
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv)/2;%%careful
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear sav_dv_positive
            
            for j=1:numel(bias_mod)
                
                for i=1:columns_positive
                    
                    pro_dv_positive( : , i ) = ...
                        vec_elements_product( [dv_negative( : , i )' dv_positive( : , i )'] + bias_mod(j) , tr_per_seq  ) ;
                    
                end
                
                dv_pos = pro_dv_positive( numel( dv_negative( : , i ) ) + 1 : end , : ) ;
                tpr.nrow{ tr_per_seq , j } = sum( dv_pos > 0 , 2 ) / size( dv_pos , 2 ) ;
                
            end
            
        end
    elseif (strcmp(method,'sav_fpr_check'))
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv)/2;%%careful
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
            
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear sav_dv_positive sav_dv_negative transition_dv_positive
            
            for j=1:numel(bias_mod)
                
                for i=1:columns_positive
                    
                    sav_dv_positive( : , i ) = filter( 1 / tr_per_seq*ones( 1 , tr_per_seq ) , 1 , dv_positive( : , i ) + bias_mod(j) ) ;
                    
                end
                for i=1:columns_negative
                    
                    sav_dv_negative( : , i ) = filter( 1 / tr_per_seq*ones( 1 , tr_per_seq ) , 1 , dv_negative( : , i ) + bias_mod(j) ) ;
                    
                end
                
                
                dv_neg = sav_dv_negative( tr_per_seq : end , : ) ;
                
                fpr.train( tr_per_seq , j) = sum( dv_neg( 1:floor(numel(dv_neg)*3/4) ) > 0 )...
                    / numel( dv_neg( 1:floor(numel(dv_neg)*3/4) ) ) ;
                
                fpr.test( tr_per_seq , j) = sum( dv_neg( floor(numel(dv_neg)*3/4)+1:end ) > 0 ) / numel( dv_neg( floor(numel(dv_neg)*3/4)+1:end ) ) ;
                
                
                
                
            end
            
        end
    elseif (strcmp(method,'sav_trans'))
        
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv)/2;%%careful
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
            
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear transition_dv_positive dv_pos dv_neg
            
            for j=1:numel(bias_mod)
                
                for im=1:50
                    
                    dv_monte_positive=dv_positive(randperm(numel(dv_positive)));
                    dv_monte_positive=dv_monte_positive(1:tr_per_seq-1);
                    dv_monte_negative=dv_negative(randperm(numel(dv_negative)));
                    dv_monte_negative=dv_monte_negative(1:tr_per_seq-1);
                    
                    if tr_per_seq>1
                        for i=1:columns_positive
                            transition_dv_positive(:,i,im) =...
                                filter( 1/tr_per_seq * ones(1,tr_per_seq),1,...
                                [dv_monte_negative; dv_monte_positive]+bias_mod(j));
                        end
                    else transition_dv_positive(tr_per_seq,:,im)=zeros(1,numel(dv_positive));
                    end
                    dv_pos(:,im)=transition_dv_positive(tr_per_seq:end,:,im);
                    %                dv_neg(:,im)=transition_dv_positive(1:tr_per_seq-1,:,im);
                    % sav_trans(im) = sum(dv_pos>0)/size(dv_pos,3);
                end
                
                
                
                %                 fpr.sav_trans( tr_per_seq , j) = sum( dv_neg( : ) > 0 ) / numel( dv_neg( : ) ) ;
                tpr.sav_trans{ tr_per_seq , j} = sum(dv_pos>0,2)/size(dv_pos,2);
                %                  for im=1:50
                %                     dv_pos_im=dv_pos(:,im);
                %                    if (numel(find(find(diff(sign([dv_pos_im(:)' 0]))<0)-find(diff(sign([0 dv_pos_im(:)']))>0)>0))>0)
                %
                %                     temp(im)=max(find(diff(sign([dv_pos_im(:)' 0]))<0)-find(diff(sign([0 dv_pos_im(:)']))>0));
                %                    else
                %                     temp(im)=0;
                %                    end
                %                 end
                %                 tpr.nrow(tr_per_seq,j)=mean(temp);
                %
            end
            
        end
    elseif (strcmp(method,'nrow'))
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv)/2;
            columns_positive=1;
            columns_negative=1;
            
        else
            
            columns_positive = numel( dv_positive ) / n_con_ex ;
            dv_positive = reshape( dv_positive , n_con_ex , columns_positive ) ;
            columns_negative = numel( dv_negative ) / n_con_ex ;
            dv_negative = reshape( dv_negative , n_con_ex , columns_negative ) ;
            
        end
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear pro_dv_positive pro_dv_negative transition_dv_positive
            
            for j=1:numel(bias_mod)
                
                for i=1:columns_positive
                    
                    pro_dv_positive( : , i ) = vec_elements_product( dv_positive( : , i ) + bias_mod(j) , tr_per_seq  ) ;
                    
                end
                for i=1:columns_negative
                    
                    pro_dv_negative( : , i ) = vec_elements_product( dv_negative( : , i ) + bias_mod(j) , tr_per_seq  ) ;
                    
                end
                
                dv_neg = pro_dv_negative( tr_per_seq : end , : ) ;
                dv_pos = pro_dv_positive( tr_per_seq : end , : ) ;
                fpr.nrow( tr_per_seq , j) = sum( dv_neg( : ) > 0 ) / numel( dv_neg( : ) ) ;
                tpr.nrow( tr_per_seq , j) = sum( dv_pos( : ) > 0 ) / numel( dv_pos( : ) ) ;
                dv_neg2=dv_negative(1:24)+bias_mod(j);
                fpr.nrow2( tr_per_seq , j) = sum( dv_neg2( : ) > 0 ) / numel( dv_neg2( : ) ) ;
                
            end
            
        end
        
    elseif (strcmp(method,'withinclass_sav'))
        
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv);
            columns=1;
            
        else
            
            columns = numel( dv ) / n_con_ex ;
            dv = reshape( dv , n_con_ex , columns) ;
            i_nclass = reshape( i_nclass, n_con_ex, columns );
            i_pclass = reshape( i_pclass, n_con_ex, columns );
            dv_positive=dv(i_pclass);
            dv_negative=dv(i_nclass);
            
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear move_dv_pclass move_dv_nclass
            
            for j=1:numel(bias_mod)
                
                
                move_dv_pclass{i} = filter(ones(1,tr_per_seq),1,temp_pclass ) + bias_mod(j) ;
                move_dv_nclass{i} = filter(ones(1,tr_per_seq),1,temp_nclass ) + bias_mod(j) ;
                
            end
            
            temp_pos=[move_dv_pclass{1};move_dv_pclass{2};move_dv_pclass{3};move_dv_pclass{4};move_dv_pclass{5};];
            temp_neg=[move_dv_nclass{1};move_dv_nclass{2};move_dv_nclass{3};move_dv_nclass{4};move_dv_nclass{5};];
            fpr.sav( tr_per_seq , j) = sum( temp_neg > 0 ) / numel( temp_neg ) ;
            tpr.sav( tr_per_seq , j) = sum( temp_pos > 0 ) / numel( temp_pos ) ;
            
        end
        
    elseif (strcmp(method,'asynch_sav'))
        
        anycell = @(x) any(x>0);
        
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv);
            columns=1;
            
        else
            
            columns = numel( dv ) / n_con_ex ;
            dv = reshape( dv , n_con_ex , columns) ;
            i_nclass = reshape( i_nclass, n_con_ex, columns );
            i_pclass = reshape( i_pclass, n_con_ex, columns );
            
        end
        
        for tr_per_seq=1:15
            
            clear move_dv_pclass move_dv_nclass
            
            for j=1:numel(bias_mod)
                
                for i=1:columns
                    
                    temp_pclass = dv(i_pclass(:,i),i) ;
                    temp_nclass = dv(i_nclass(:,i),i) ;
                    
                    if (tr_per_seq<=numel(temp_pclass))
                        move_dv_pclass{i} = filter( ones(1,tr_per_seq),1,temp_pclass ) + bias_mod(j);
                    else
                        move_dv_pclass{i} = NaN ;
                    end
                    
                    if (tr_per_seq<=numel(temp_nclass))
                        move_dv_nclass{i} = filter( ones(1,tr_per_seq),1,temp_nclass ) + bias_mod(j) ;
                    else
                        move_dv_nclass{i} = NaN ;
                    end
                    
                    
                end
                if(tr_per_seq==12 && j==51)
                    x=2;
                end
                temp_neg = cat( 1 , move_dv_nclass{:} );
                temp=cellfun(@isnan,move_dv_pclass,'UniformOutput',0);
                move_dv_pclass(cellfun(@(x) any(x>0),temp))=[];
                fpr.sav( tr_per_seq , j) = sum( temp_neg(:) > 0 ) / numel( temp_neg(:) ) ;
                tpr.sav( tr_per_seq , j) = sum( cellfun( anycell , move_dv_pclass )) / numel( move_dv_pclass );
                
            end
            
        end
        
    elseif (strcmp(method,'asynch_dec_sav'))
        
        anycellfn = @(x) any(x>0);
        
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv);
            columns=1;
            
        else
            
            columns = numel( dv ) / n_con_ex ;
            dv = reshape( dv , n_con_ex , columns) ;
            i_nclass = reshape( i_nclass, n_con_ex, columns );
            i_pclass = reshape( i_pclass, n_con_ex, columns );
            
        end
        
        for tr_per_seq=min_tr_per_seq:max_tr_per_seq
            
            clear move_dv_pclass move_dv_nclass
            
            for j=1:numel(bias_mod)
                
                for i=1:columns
                    
                    dv_trial = filter( 1/tr_per_seq*ones( 1 , tr_per_seq ) , 1 , dv( : , i ) )';
                    %dv_trial = dv;
                    
                    temp_pclass = dv_trial(i_pclass(:,i)) ;
                    temp_nclass = dv_trial(i_nclass(:,i)) ;
                    
                end
                
                dv_neg_full = cat( 2 , move_dv_nclass{:} );
                
                nan_pos_trials=cellfun(@isnan,move_dv_pclass,'UniformOutput',0);
                move_dv_pclass(cellfun(@(x) any(x>0),nan_pos_trials))=[];
                
                tpr.dec{ tr_per_seq , j} = sum( cellfun( anycellfn , move_dv_pclass )) / numel( move_dv_pclass );
                
            end
            
        end
        
    elseif (strcmp(method,'asynch_dec_nrow'))
        
        anycellfn = @(x) any(x>0);
        
        if (strcmp(n_con_ex,'all'))
            
            n_con_ex=numel(dv);
            columns=1;
            
        else
            
            columns = numel( dv ) / n_con_ex ;
            dv = reshape( dv , n_con_ex , columns) ;
            i_nclass = reshape( i_nclass, n_con_ex, columns );
            i_pclass = reshape( i_pclass, n_con_ex, columns );
            
        end
        
        %         for i=1:columns
        %
        %             extra=find(i_pclass(:,i)==1);
        %             before=extra(1)-1;
        %             after=extra(end)+1;
        %             if (before>0)
        %                 i_pclass([before],i)=true;
        %                 i_nclass([before],i)=false;
        %             end
        %             if (after<=60)
        %                 i_pclass([after],i)=true;
        %                 i_nclass([after],i)=false;
        %             end
        %
        %         end
        
        for dwell_segments=1:5
            
            for move_duration=1:10
                
                clear move_dv_pclass move_dv_nclass
                
                for j=1:numel(bias_mod)
                    
                    for i=1:columns
                        %%%% add before period2
                        dv_trial = vec_elements_product( dv( : , i ) + bias_mod(j) , dwell_segments );
                        %dv_trial = dv;
                        %                         detections = find(dv_trial==1);
                        %                         while ~isempty(detections)
                        %                             dv_trial(detections(1))=2;
                        %                             if (detections(1)<n_con_ex-2)
                        %                                % dv_trial(detections(1)+1:detections(1)+1)=-1;
                        %                             end
                        %                             detections=find(dv_trial==1);
                        %                         end
                        %                         dv_trial(dv_trial==2)=1;
                        
                        temp_pclass = dv_trial(i_pclass(:,i)) ;
                        temp_nclass = dv_trial(i_nclass(:,i)) ;
                        %                         if (sp==2 & j==51)
                        %                             keyboard
                        %                         end
                        if (move_duration<=numel(temp_pclass))
                            move_dv_pclass{i} = temp_pclass(1:move_duration);
                        else
                            move_dv_pclass{i} = NaN ;
                        end
                        
                        if (move_duration<=numel(temp_nclass))
                            move_dv_nclass{i} = temp_nclass;
                        else
                            move_dv_nclass{i} = NaN ;
                        end
                        
                        
                    end
                    
                    dv_neg_full = cat( 2 , move_dv_nclass{:} );
                    
                    nan_pos_trials=cellfun(@isnan,move_dv_pclass,'UniformOutput',0);
                    move_dv_pclass(cellfun(anycellfn,nan_pos_trials))=[];
                    
                    fpr.dec( move_duration , j , dwell_segments) = sum( dv_neg_full(:) > 0 ) / numel( dv_neg_full(:) ) ;
                    tpr.dec( move_duration , j , dwell_segments) = sum( cellfun( anycellfn , move_dv_pclass )) / numel( move_dv_pclass );
                    
                end
                
            end
            
        end
        
    end
    
    dm(sp).fpr = fpr ;
    dm(sp).tpr = tpr ;
    dm(sp).perf = perf ;
    dm(sp).bias = bias_mod;
    clear fpr tpr
    % n_con_ex='all';
   % fprintf('carefull nconex all');
end

end