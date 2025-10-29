ARG robotframework_image
FROM ${robotframework_image}

ARG non_root_user=tests
ENV HOME=/home/${non_root_user}

RUN mkdir -p ${HOME}/tests/output ${HOME}/tests/robot ${HOME}/bin

WORKDIR ${HOME}/tests

COPY robot/ tests/robot

CMD ["robot", "--outputdir", "output", "robot"]