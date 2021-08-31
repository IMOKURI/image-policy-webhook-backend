import logging

from flask import Flask, jsonify

APP = Flask(__name__)
APP.logger.setLevel(logging.INFO)


from api import image_policy

APP.register_blueprint(image_policy.BP)


@APP.errorhandler(404)
def error_not_found(_):
    return jsonify({"error": "404"}), 404
