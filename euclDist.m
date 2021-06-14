% Modified Anushree R. Chaphalkar 26/5/2016 (preallocation + editing)
% Chaitanya Athale 07-02-2013
% Function takes a series of x and y coords
% Output: euclidean distance column of n-1 pts 
function d = euclDist( xy )
xy= double(xy);
n = size(xy,1);
d= zeros(n-1,1); % Anu
for s = 1:n-1
    d(s)= ((xy(s+1,1)-xy(s,1))^2 + (xy(s+1,2)-xy(s,2))^2)^0.5;
end

end