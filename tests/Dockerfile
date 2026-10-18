FROM robotframework

RUN mkdir -p ${HOME}/tests/output ${HOME}/tests/robot ${HOME}/bin

WORKDIR ${HOME}/tests

COPY robot/ tests/robot

CMD ["robot", "--outputdir", "output", "robot"]