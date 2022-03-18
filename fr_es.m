function l = fr_es(A, dt)

for j = (dt+1):(length(A))
 l(j) = sum(A((j-dt):j))./(dt);
end 

end

