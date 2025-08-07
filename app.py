from  flask import flask
import os

app= flask(__name__)

@app.route('/')
def hello():
	return 'hello from a simple python ap deplooyed with terraform and argocd on gcp'

if __name__ == "__main__":

	port = int(os.environ.get("Port", 5000))
	app.run(debug=True, host='0.0.0.0', port=port)
