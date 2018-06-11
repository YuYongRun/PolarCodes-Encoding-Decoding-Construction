function x = CASCL_decoder(y, L, info_bits, frozen_bits, det, lambda_offset, llr_layer_vec, bit_layer_vec)%2018.1.7.14:16 Yu Y. R.
%LLR-based SCL deocoder

%const
N = length(y);
m = log2(N);

%memory declared
P = zeros(2*N - 1, L);
C = zeros(2*N - 1, 2*L);
u = zeros(N, L);
PM = zeros(L, 1);
activepath = zeros(L, 1);

%initialize
P(end - N + 1 : end, 1) = y;
activepath(1) = 1;

%indicate whether the list size reaches L or not
indicator = 0;

%decoding starts
%default: in the case of path clone, origianl always corresponds to bit 0, while the new path bit 1. 
for phi = 0 : N - 1
    
    layer = llr_layer_vec(phi + 1);
    phi_mod_2 = mod(phi, 2);
    
    for l_index = 1 : L
        
        if activepath(l_index) == 0
            continue;
        end
 
        if phi == 0
            for i_layer = m - 1 : -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                index_2 = lambda_offset(i_layer + 2);
                for beta = 0 : index_1 - 1
                    P(beta + index_1, l_index) = sign(P(2*beta + index_2, l_index)) *  sign(P(2*beta + 1 + index_2, l_index)) * ...
                        min(abs(P(2*beta + index_2, l_index)), abs(P(2*beta + 1 +index_2, l_index)));
                end
            end
        else
            for i_layer = layer: -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                index_2 = lambda_offset(i_layer + 2);
                if i_layer == layer
                    for beta = 0 : index_1 - 1
                        P(beta + index_1, l_index) = (1 - 2*C(beta + index_1, 2 * l_index - 1)) * P(2 * beta + index_2, l_index) + P(2 * beta + 1 + index_2, l_index);
                    end
                else
                    for beta = 0 : index_1 - 1
                        P(beta + index_1, l_index) = sign(P(2 * beta + index_2, l_index)) *  sign(P(2 * beta + 1 + index_2, l_index)) * ...
                            min(abs(P(2 * beta + index_2, l_index)), abs(P(2 * beta + 1 + index_2, l_index)));
                    end
                end
            end
        end
    end


    if frozen_bits(phi + 1) == 0
        
        num_current_path = sum(activepath);
   
        if (num_current_path < L) && (indicator == 0)
            
            for l_index = 1 : num_current_path
                if activepath(l_index) == 0
                    continue;
                end

                index = l_index + num_current_path;%offset to find an empty path
                activepath(index) = 1;
                
                bit_column_1 = 2 * l_index - 1;
                bit_column_2 = 2 * l_index;
                new_bit_column_1 = 2 * index - 1;
                new_bit_column_2 = 2 * index;

                P(:, index) = P(:, l_index);
                C(:, new_bit_column_1) = C(:, bit_column_1);
                C(:, new_bit_column_2) = C(:, bit_column_2);
                
                u(:, index) = u(:, l_index);
                u(phi + 1, l_index) = 0;
                u(phi + 1, index) = 1;
 
                if phi_mod_2 == 0
                    C(1, bit_column_1) = 0;
                    C(1, new_bit_column_1) = 1;
                    if P(1, l_index) < 0                
                        PM_tmp = PM(l_index);
                        PM(l_index) = PM(l_index) + abs(P(1, l_index));
                        PM(index(1)) = PM_tmp;
                    else
                        PM_tmp = PM(l_index);
                        PM(l_index) = PM(l_index);
                        PM(index(1)) = PM_tmp  + abs(P(1, l_index));
                    end
                else
                    C(1, bit_column_2) = 0;
                    C(1, new_bit_column_2) = 1;
                    if P(1, l_index) < 0                
                        PM_tmp = PM(l_index);
                        PM(l_index) = PM(l_index) + abs(P(1, l_index));
                        PM(index(1)) = PM_tmp;
                    else
                        PM_tmp = PM(l_index);
                        PM(l_index) = PM(l_index);
                        PM(index(1)) = PM_tmp  + abs(P(1, l_index));
                    end
                end
                
                
                if phi_mod_2  == 1
                    layer = bit_layer_vec(phi + 1);
                    for i_layer = 0 : layer
                        index_1 = lambda_offset(i_layer + 1);
                        switch i_layer
                            case layer
                                for beta = index_1 : 2 * index_1 - 1
                                    C(2 * beta, new_bit_column_1) = mod(C(beta, new_bit_column_1) + C(beta, new_bit_column_2), 2);
                                    C(2 * beta + 1, new_bit_column_1) = C(beta, new_bit_column_2);
                                    C(2 * beta, bit_column_1) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                    C(2 * beta + 1, bit_column_1) = C(beta, bit_column_2);
                                end
                            otherwise
                                for beta = index_1 : 2 * index_1 - 1
                                    C(2 * beta, new_bit_column_2) = mod(C(beta, new_bit_column_1) + C(beta, new_bit_column_2), 2);
                                    C(2 * beta + 1, new_bit_column_2) = C(beta, new_bit_column_2);
                                    C(2 * beta, bit_column_2) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                    C(2 * beta + 1, bit_column_2) = C(beta, bit_column_2);
                                end
                        end
                    end
                end            
            end  
        else
            indicator = 1;
            
            PM_pair = zeros(2, L);
           
            for l_index = 1 : L
                PM_0 = log(1 + exp(-P(1, l_index)));
                PM_1 = log(1 + exp(P(1, l_index)));
                PM_pair(1, l_index) = PM(l_index) + PM_0;
                PM_pair(2, l_index) = PM(l_index) + PM_1;
            end
        
            PM_sort = sort(PM_pair(:));
            PM_cv = PM_sort(L);
            compare = zeros(2, L);
  
            cnt = 0;
            for j = 1 : L
                for i = 1 : 2
                    
                    if cnt == L
                        break;
                    end
                    
                    if PM_pair(i, j) <= PM_cv
                        compare(i, j) = 1;
                        cnt = cnt + 1;
                    else
                        compare(i, j) = 0;
                    end
                end
            end
            
            kill_index = zeros(L, 1);%to record the index of the path that is killed
            kill_cnt = 0;%the total number of killed path
            %the above two variables consist of a stack

            for i = 1 : L
      
                if (compare(1, i) == 0)&&(compare(2, i) == 0)%which indicates that this path should be killed
                    activepath(i) = 0;
                    kill_cnt = kill_cnt + 1;%push stack
                    kill_index(kill_cnt) = i;  
                end
            end
       
            for l_index = 1 : L
                
                if activepath(l_index) == 0
                    continue;
                end
                
                path_state = compare(1, l_index) * 2 + compare(2, l_index);
                
                switch path_state
                    case 1
                        u(phi + 1, l_index) = 1;
                        bit_column_1 = 2 * l_index - 1;
                        bit_column_2 = 2 * l_index;
                        if phi_mod_2 == 0
                            C(1, bit_column_1) = 1;
                            PM_tmp = log(1 + exp(P(1, l_index)));
                            PM(l_index) = PM(l_index) + PM_tmp;
                        else
                            C(1, bit_column_2) = 1;
                            PM_tmp = log(1 + exp(P(1, l_index)));
                            PM(l_index) = PM(l_index) + PM_tmp;
                        end
                        
                        if phi_mod_2  == 1
                            layer = bit_layer_vec(phi + 1);
                            for i_layer = 0 : layer
                                index_1 = lambda_offset(i_layer + 1);
                                switch i_layer
                                    case layer
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, bit_column_1) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_1) = C(beta, bit_column_2);
                                        end
                                    otherwise
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, bit_column_2) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_2) = C(beta, bit_column_2);
                                        end
                                end
                            end
                        end
                        
                    case 2
                        bit_column_1 = 2 * l_index - 1;
                        bit_column_2 = 2 * l_index;
                        u(phi + 1, l_index) = 0;
                        
                        if phi_mod_2 == 0
                            C(1, bit_column_1) = 0;
                            PM_tmp = log(1 + exp(-P(1, l_index)));
                            PM(l_index) = PM(l_index) + PM_tmp;
                        else
                            C(1, bit_column_2) = 0;
                            PM_tmp = log(1 + exp(-P(1, l_index)));
                            PM(l_index) = PM(l_index) + PM_tmp;
                        end
                        
                        if phi_mod_2  == 1
                            layer = bit_layer_vec(phi + 1);
                            for i_layer = 0 : layer
                                index_1 = lambda_offset(i_layer + 1);
                                switch i_layer
                                    case layer
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, bit_column_1) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_1) = C(beta, bit_column_2);
                                        end
                                    otherwise
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, bit_column_2) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_2) = C(beta, bit_column_2);
                                        end
                                end
                            end
                        end
                        
                    case 3 
                        index = kill_index(kill_cnt);
                        kill_cnt = kill_cnt - 1;%pop stack
                        activepath(index(1)) = 1;
                        
                        new_bit_column_1 = 2 * index - 1;
                        new_bit_column_2 = 2 * index;
                        bit_column_1 = 2 * l_index - 1;
                        bit_column_2 = 2 * l_index;
                        
                        P(:, index(1)) = P(:, l_index);
                        C(:, new_bit_column_1) = C(:, bit_column_1);
                        C(:, new_bit_column_2) = C(:, bit_column_2);
                        u(:, index) = u(:, l_index);
                        u(phi + 1, l_index) = 0;
                        u(phi + 1, index) = 1;
                        
                        if phi_mod_2 == 0
                            C(1, bit_column_1) = 0;
                            C(1, new_bit_column_1) = 1;
                            PM_0 = log(1 + exp(-P(1, l_index)));
                            PM_1 = log(1 + exp(P(1, l_index)));
                            PM_tmp = PM(l_index);
                            PM(l_index) = PM(l_index) + PM_0;
                            PM(index(1)) = PM_tmp + PM_1;
                        else
                            C(1, bit_column_2) = 0;
                            C(1, new_bit_column_2) = 1;
                            PM_0 = log(1 + exp(-P(1, l_index)));
                            PM_1 = log(1 + exp(P(1, l_index)));
                            PM_tmp = PM(l_index);
                            PM(l_index) = PM(l_index) + PM_0;
                            PM(index(1)) = PM_tmp + PM_1;
                        end
                        
                        if phi_mod_2  == 1
                            layer = bit_layer_vec(phi + 1);
                            for i_layer = 0 : layer
                                index_1 = lambda_offset(i_layer + 1);
                                switch i_layer
                                    case layer
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, new_bit_column_1) = mod(C(beta, new_bit_column_1) + C(beta, new_bit_column_2), 2);
                                            C(2 * beta + 1, new_bit_column_1) = C(beta, new_bit_column_2);
                                            C(2 * beta, bit_column_1) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_1) = C(beta, bit_column_2);
                                        end
                                    otherwise
                                        for beta = index_1 : 2 * index_1 - 1
                                            C(2 * beta, new_bit_column_2) = mod(C(beta, new_bit_column_1) + C(beta, new_bit_column_2), 2);
                                            C(2 * beta + 1, new_bit_column_2) = C(beta, new_bit_column_2);
                                            C(2 * beta, bit_column_2) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                            C(2 * beta + 1, bit_column_2) = C(beta, bit_column_2);
                                        end
                                end
                            end
                        end
                end
            end
        end
    else
        
        for l_index = 1 : L
            if activepath(l_index) == 0
                continue;
            end
            
            bit_column_1 = 2 * l_index - 1;
            bit_column_2 = 2 * l_index;
            
            PM_tmp = log(1 + exp(-P(1,l_index)));
            PM(l_index) = PM(l_index) + PM_tmp;
            
            if phi_mod_2 == 0
                C(1, 2*l_index - 1) = 0;
            else
                C(1, 2*l_index) = 0;
            end
            
            if phi_mod_2  == 1
                layer = bit_layer_vec(phi + 1);
                for i_layer = 0 : layer
                    index_1 = lambda_offset(i_layer + 1);
                    switch i_layer
                        case layer
                            for beta = index_1 : 2 * index_1 - 1
                                C(2 * beta, bit_column_1) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                C(2 * beta + 1, bit_column_1) = C(beta, bit_column_2);
                            end
                        otherwise
                            for beta = index_1 : 2 * index_1 - 1
                                C(2 * beta, bit_column_2) = mod(C(beta, bit_column_1) + C(beta, bit_column_2), 2);
                                C(2 * beta + 1, bit_column_2) = C(beta, bit_column_2);
                            end
                    end
                end
            end  
        end
    end

end
%select the best path
does_this_path_pass_crc = ones(L, 1);
for l_index = 1 : L
    u_tmp = u(:, l_index);
    info_with_crc = u_tmp(info_bits);
    [~, err] = detect(det, info_with_crc);
    does_this_path_pass_crc(l_index) = err;
end

if any(does_this_path_pass_crc == 0)
    path_index = find(does_this_path_pass_crc == 0);
    min_PM = realmax;
    optimal_index = 0;
    for i = 1 : length(path_index)
        if PM(path_index(i)) < min_PM
            min_PM = PM(path_index(i));
            optimal_index = path_index(i);
        end
    end
    x = C(end - N + 1 : end, 2 * optimal_index - 1);
else
    index = find(PM == min(PM));
    x = C(end - N + 1 : end, 2*index(1) - 1);
end
    
end