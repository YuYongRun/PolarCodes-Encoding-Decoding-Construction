function x = my_polar_encode(u, lambda_offset, layer_vec)
N = length(u);
m = log2(N);
C = zeros(2 * N - 1, 1);
C(end - N + 1 : end) = u;
x = zeros(N, 1);

for phi = 0 : N - 1
    switch phi
        case 0
            for i_layer = m - 1 : -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                for beta = index_1 : 2 * index_1 - 1
                    C(beta) = C(2 * beta) + C(2 * beta + 1);
                end
            end
        otherwise
            layer = layer_vec(phi + 1);
            for i_layer = layer: -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                switch i_layer
                    case layer
                        for beta = index_1 : 2 * index_1 - 1
                            C(beta) = C(2 * beta + 1);
                        end
                    otherwise
                        for beta = index_1 : 2 * index_1 - 1
                            C(beta) = C(2 * beta) + C(2 * beta + 1);
                        end
                end
            end
    end

%     if phi == 0
%         layer = m - 1;
%     else
%         psi = phi;
%         while(mod(psi, 2) == 0)
%             psi = floor(psi/2);
%             layer = layer + 1;
%         end
%     end
%     
%     if phi == 0
%         for i_layer = m - 1 : -1 : 0
%             index_1 = lambda_offset(i_layer + 1);
%             index_2 = lambda_offset(i_layer + 2);
%             for beta = 0 : index_1 - 1
%                 C(beta + index_1) = mod(C(2 * beta + index_2) + C(2 * beta + index_2 + 1), 2);
%             end
%         end
%     else
%         for i_layer = layer: -1 : 0
%             index_1 = lambda_offset(i_layer + 1);
%             index_2 = lambda_offset(i_layer + 2);
%             if i_layer == layer
%                 for beta = 0 : index_1 - 1
%                     C(beta + index_1) = C(2 * beta + index_2 + 1);
%                 end
%             else
%                 for beta = 0 : index_1 - 1
%                     C(beta + index_1) = mod(C(2 * beta + index_2) + C(2 * beta + index_2 + 1), 2);
%                 end
%             end
%         end
%     end
    x(phi + 1) = C(1);
end

x = mod(x, 2);
end
    
    
