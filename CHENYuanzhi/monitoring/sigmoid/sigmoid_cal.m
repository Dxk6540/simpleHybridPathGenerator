function [Fitted_y, J] = sigmoid_cal(Input_x,Fitting_par,Reference_y)
x_num = size(Input_x,2);
Y0 = zeros(size(Input_x));

zoom_par = Fitting_par(1);
moving_par = Fitting_par(2) + Fitting_par(3);
symmery_axis = Fitting_par(3);
height = Fitting_par(4);

var_x0 = Input_x;

% var_x1 = var_x0 * zoom_par;
% var_x2 = var_x1 - moving_par;

var_x1 = var_x0 - moving_par;
var_x2 = var_x1 * zoom_par;

var_sym_x0 = symmery_axis - (Input_x - symmery_axis);
var_sym_x1 = var_sym_x0 - moving_par;
var_sym_x2 = var_sym_x1 * zoom_par;

% sym_axis_mov = (symmery_axis - moving_par) * zoom_par;

for i = 1:x_num
    if var_x0(i) <= symmery_axis
        Y0(i) = sigmoid_equa(var_x2(i));
        % Y0(i) = sigmoid_cal(symmery_axis - (var_x2(i) - symmery_axis));
    else
        Y0(i) = sigmoid_equa(var_sym_x2(i));
        % Y0(i) = sigmoid_cal(var_x2(i));
    end
end

% norm the height

max0 = max(Y0);
Y1 = Y0 / max0 * height;

Fitted_y = Y1;

Error_y = abs(Reference_y - Fitted_y);
J = norm(Error_y,1);%% sum


end