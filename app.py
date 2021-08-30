import ssl

from api import APP

if __name__ == "__main__":
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ssl_context.load_cert_chain(
        '/certs/image-policy.crt',
        '/certs/image-policy-key.pem'
    )

    APP.run(host="0.0.0.0", port=10443, ssl_context=ssl_context)
