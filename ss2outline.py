from base64 import b64encode

METHOD = input('METHOD, e.g. chacha20-ietf-poly1305 -->')
if not METHOD:
    METHOD='chacha20-ietf-poly1305'
PASSWORD = input('password-->')
PORT = input("port--> ")
IP = input("IP or domain--> ")
print(f"DEBUG>  Method: {METHOD} ServerAddr: {IP}:{PORT} Password: ***{PASSWORD[-4:]}")
BASE64 = b64encode(f"{METHOD}:{PASSWORD}".encode('ascii'))
print(f"ss://{BASE64.decode()}@{IP}:{PORT}")
