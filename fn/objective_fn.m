function loss = objective_fn(gamma, model, s, test_set)
    model.gamma = gamma;
    model = gaussian_frame_weights(model);
    test_set = generate_trajectory_weighted(model, test_set);
    loss = loss_fn(s, test_set); 
end