#
FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
# 作者
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
