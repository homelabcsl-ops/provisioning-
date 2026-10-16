#!/bin/bash
groupadd -g 3000 developers
useradd -u 2024 -g developers -s /bin/bash jr_dev
echo "jr_dev:Changepassword123" | chpasswd
