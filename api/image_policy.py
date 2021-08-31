import json
import logging
import os

from flask import Blueprint, jsonify, request, current_app

BP = Blueprint("image_policy", __name__, url_prefix="/image-policy")


@BP.route("/")
def index():
    return jsonify({"ready": "ok"})


@BP.route("/base-image", methods=["POST"])
def base_image():
    logger = current_app.logger
    data = json.loads(request.get_data())
    logger.info(f"Request: {data}")

    image = Image(data)

    image.check()

    logger.info(f"Response: {image.response}")
    return jsonify(image.response), image.return_code


class Image:
    VALID_REGISTRIES = [
        "imokuri123/",
        "gcr.k8s.io/",
        "docker.io/",
        "quay.io/",
    ]

    def __init__(self, data):
        self.data = data
        self.response = {
            "apiVersion": "imagepolicy.k8s.io/v1alpha1",
            "kind": "ImageReview",
            "status": {"allowed": True},
        }
        self.return_code = 200

    def check(self):
        if self.is_invalid_schema():
            return
        if self.is_invalid_registry():
            return

    def is_invalid_schema(self):
        if self.data["kind"] != "ImageReview":
            self.response["status"]["allowed"] = False
            self.response["status"][
                "reason"
            ] = f"Invalid request. kind: {self.data['kind']}"
            self.return_code = 400
            return True
        return False

    def is_invalid_registry(self):
        for container in self.data["spec"]["containers"]:
            if all(
                not container["image"].startswith(registry)
                for registry in self.VALID_REGISTRIES
            ):
                self.response["status"]["allowed"] = False
                self.response["status"][
                    "reason"
                ] = f"Invalid base image. image: {container['image']}"
                return True
        return False

    def check_base_image(self):
        # TODO
        pass
