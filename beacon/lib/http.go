package lib

import "github.com/valyala/fasthttp"

func CreateHttpServer() *fasthttp.Server {
	return &fasthttp.Server{
		DisableKeepalive:              true,
		CloseOnShutdown:               true,
		GetOnly:                       true,
		DisablePreParseMultipartForm:  true,
		DisableHeaderNamesNormalizing: true,
		NoDefaultServerHeader:         true,
		NoDefaultContentType:          true,
	}
}
