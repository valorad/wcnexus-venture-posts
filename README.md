[![Docker Stars](https://img.shields.io/docker/stars/valorad/wcnexus-venture.svg?style=flat-square)](https://hub.docker.com/r/valorad/wcnexus-venture/)

# wcnexus-venture
Venture (Blog) part of wcnexus.com powered by [hugo](https://github.com/gohugoio/hugo)

## Deployment
``` bash
docker run --name wcnexus-venture-c1 \
-e EXEC_USER=$USER -e EXEC_USER_ID=$UID \
-v /path/to/local/output:/dist \
valorad/wcnexus-venture 
```

## Automatic git pull on blog push
Consider implementation of [xmj-alliance/webhook-koa](https://github.com/xmj-alliance/webhook-koa)

## Development
This is just a blog. All you need to do is start writing blogs!
Please refer to https://gohugo.io/getting-started/quick-start/.

## License
MIT