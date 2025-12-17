function ReplaceParameterInRAMS(project_folder, param_name, new_value)

lines = readlines([project_folder 'MainRAMS.txt']);
param_line_index = 1;
while 1
    s = lines(param_line_index);
    if (contains(s, param_name))
        break
    end
    param_line_index = param_line_index + 1;
end

words = split(s);
words{3} = [num2str(new_value) ';']; 
new_s = join(words);
new_s = new_s{1};

new_lines = [lines(1:param_line_index - 1); new_s; lines(param_line_index + 1:end)];
writelines(new_lines, [project_folder 'MainRAMS.txt'])

end