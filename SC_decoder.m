function x = SC_decoder(llr, frozen_bits, lambda_offset, llr_layer_vec, bit_layer_vec)%x is code word, not sorcue seq.
N = length(llr);
m = log2(N);
P = zeros(2 * N - 1, 1);
C = zeros(2 * N - 1, 2);
P(end - N + 1 : end) = llr;
for phi = 0 : N - 1
    
    switch phi
        case 0
            for i_layer = m - 1 : -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                for beta = index_1 : 2 * index_1 - 1
                    sign_1 = sign(P(2 * beta));
                    sign_2 = sign(P(2 * beta + 1));
                    a = abs(P(2 * beta));
                    b = abs(P(2 * beta + 1));
                    P(beta) =  sign_1 * sign_2 * min(a, b);
                end
            end
        otherwise
            layer = llr_layer_vec(phi + 1);
            for i_layer = layer: -1 : 0
                index_1 = lambda_offset(i_layer + 1);
                switch i_layer
                    case layer
                        for beta = index_1 : 2 * index_1 - 1
                            P(beta) = (1 - 2 * C(beta, 1)) * P(2 * beta) + P(2 * beta + 1);
                        end
                    otherwise
                        for beta = index_1 : 2 * index_1 - 1
                            sign_1 = sign(P(2 * beta));
                            sign_2 = sign(P(2 * beta + 1));
                            a = abs(P(2 * beta));
                            b = abs(P(2 * beta + 1));
                            P(beta) =  sign_1 * sign_2 * min(a, b);
                        end
                end
            end
    end
    
    phi_mod_2 = mod(phi, 2);
    
    if frozen_bits(phi + 1) == 1
        C(1, 1 + phi_mod_2) = 0;
    else
        C(1, 1 + phi_mod_2) = P(1) < 0;
    end
    
    if phi_mod_2  == 1
        layer = bit_layer_vec(phi + 1);
        for i_layer = 0 : layer
            index_1 = lambda_offset(i_layer + 1);
            switch i_layer
                case layer
                    for beta = index_1 : 2 * index_1 - 1
                        C(2 * beta, 1) = mod(C(beta, 1) + C(beta, 2), 2);
                        C(2 * beta + 1, 1) = C(beta, 2);
                    end
                otherwise
                    for beta = index_1 : 2 * index_1 - 1
                        C(2 * beta, 2) = mod(C(beta, 1) + C(beta, 2), 2);
                        C(2 * beta + 1, 2) = C(beta, 2);
                    end
            end
        end
    end

end

x = C(end - N + 1 : end, 1);

end


