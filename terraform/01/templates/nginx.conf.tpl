%{for s in services ~}
upstream ${s.name} {
    server 127.0.0.1:${s.port}
}

%{ endfor ~}

server {
    listen 80;
%{ for s in services ~}
%{ if s.public ~} 
    location /${s.name}/ {
        proxy_pass http://${s.name}/;
    }
%{ endif ~}
%{ endfor ~}    
}
