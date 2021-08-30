import json

from flask import Blueprint, jsonify, request

BP = Blueprint("image_policy", __name__, url_prefix="/image-policy")


@BP.route("/")
def index():
    return jsonify({"ready": "ok"})


@BP.route("/base-image", methods=["POST"])
def base_image():
    response = {
        "apiVersion": "imagepolicy.k8s.io/v1alpha1",
        "kind": "ImageReview",
        "status": {"allowed": True},
    }
    data = json.loads(request.get_data())

    if data["kind"] != "ImageReview":
        response["status"]["allowed"] = False
        response["status"]["reason"] = f"Invalid request. kind: {data['kind']}"
        return jsonify(response), 400

    image = Image()

    for container in data["spec"]["containers"]:
        if not image.check_to_allow_base_image(container["image"]):
            response["status"]["allowed"] = False
            response["status"]["reason"] = f"Invalid base image. image: {container['image']}"
            return jsonify(response), 403



    return jsonify(response)


class Image:
    def __init__(self):
        pass

    def check_to_allow_base_image(self, image_tag):
        # TODO
        return image_tag.startswith("imokuri")
