function str_num = num2str_fixed_width( k, num_chars )

if( nargin < 2 )
  num_chars = 4;
end

str_num = num2str(k);
while( numel(str_num) < num_chars )
  str_num = ['0' str_num]; %#ok<AGROW>
end

end
