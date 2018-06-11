function [bler, ber] = simulation(N, K, design_epsilon, max_runs, max_err, resolution, ebno_vec, list_size_vec, gen, det, crc_length)
R = (K - crc_length)/N;
% R = K/N;
lambda_offset = 2.^(0 : log2(N));
llr_layer_vec = get_llr_layer(N);
bit_layer_vec = get_bit_layer(N);

%Bhattacharyya Code (BEC) Construction
% channels = get_BEC_IWi(N, design_epsilon);
% [~, channel_ordered] = sort(channels, 'descend');
% info_bits = sort(channel_ordered(1 : K), 'ascend');
% frozen_bits = ones(N , 1);
% frozen_bits(info_bits) = 0;
% info_bits_logical = logical(mod(frozen_bits + 1, 2));

%Gaussian approximation Code Construction
% design_snr = ebno_vec(end);
% alpha = sqrt(0.8);
% sigma_cc = alpha * 1/sqrt(2 * R) * 10^(-design_snr/20);
design_snr = 2.5;
sigma_cc = 1/sqrt(2 * R) * 10^(-design_snr/20);
[channels, ~] = GA(sigma_cc, N);
[~, channel_ordered] = sort(channels, 'descend');
info_bits = sort(channel_ordered(1 : K), 'ascend');
frozen_bits = ones(N , 1);
frozen_bits(info_bits) = 0;
info_bits_logical = logical(mod(frozen_bits + 1, 2));


%beta expansion
% beta = sqrt(sqrt(2));
% channels = beta_expansion_polar_code_construction(N, beta);
% [~, channel_ordered] = sort(channels, 'descend');
% info_bits = sort(channel_ordered(1 : K));
% frozen_bits = ones(N , 1);
% frozen_bits(info_bits) = 0;

%Special nodes
node_type_matrix = get_node_structure(frozen_bits);

%Results Stored
bler = zeros(length(ebno_vec), length(list_size_vec));
num_runs = zeros(length(ebno_vec), length(list_size_vec));
ber = 0;
%Loop starts
tic
for i_run = 1 : max_runs
    if  mod(i_run, max_runs/resolution) == 1
        disp(' ');
        disp(['Sim iteration running = ' num2str(i_run)]);
        disp(['N = ' num2str(N) ' K = ' num2str(K)]);
        disp(['List size = ' num2str(list_size_vec)]);
        disp('Current accurate block error performance');
        disp(num2str([ebno_vec'  bler./num_runs]));
        disp(' ')
    end
    %To avoid redundancy
    info  = rand(K - crc_length, 1) > 0.5;
    info_with_crc = generate(gen, info);
    u = zeros(N, 1);
    u(info_bits_logical) = info_with_crc;
    x = my_polar_encode(u, lambda_offset, llr_layer_vec);
    bpsk = 1 - 2 * x;
    noise = randn(N, 1);
    prev_decoded = zeros(length(ebno_vec), length(list_size_vec));
    for i_ebno = 1 : length(ebno_vec)
        sigma = 1/sqrt(2 * R) * 10^(-ebno_vec(i_ebno)/20);
        y = bpsk + sigma * noise;
        llr = 2/sigma^2*y;
        for i_list = 1 : length(list_size_vec)
            if i_list ~= 1
                if bler(i_ebno, i_list) == max_err
                    continue;
                end
            else
                if all(bler(i_ebno, 2 : end) == max_err)
                    continue
                end
            end
            num_runs(i_ebno, i_list) = num_runs(i_ebno, i_list) + 1;
            run_sim = 1;
            for i_ebno2 = 1 : i_ebno
                for i_list2 = 1 : i_list
                    if prev_decoded(i_ebno2, i_list2)
                        run_sim = 0;
                    end
                end
            end
            if run_sim == 0
                continue;
            end
            if list_size_vec(i_list) == 1
%                 if N >= 2^15
%                     x_esti = Advanced_SC_decoder(llr, frozen_bits, node_type_matrix, lambda_offset);
%                 else
                    x_esti = SC_decoder(llr, frozen_bits, lambda_offset, llr_layer_vec, bit_layer_vec);
%                 end
            else
                x_esti = CASCL_decoder(llr, list_size_vec(i_list), info_bits, frozen_bits, det, lambda_offset, llr_layer_vec, bit_layer_vec);
            end
            
            if any(x_esti ~= x)
                bler(i_ebno, i_list) = bler(i_ebno, i_list) + 1;
            else
                prev_decoded(i_ebno, i_list) = 1;
            end
            
        end
    end
end
toc
end

