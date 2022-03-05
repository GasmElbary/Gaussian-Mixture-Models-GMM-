function p = Normal(x, mu, sigma)
p = exp( -(x-mu).^2 / (2*sigma^2) ) / (sigma * sqrt(2*pi) );
end