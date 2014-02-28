region=`ec2-metadata | sed -n 's/^local-hostname: ip-[0-9-]*\.\(.*\)\.compute\.internal/\1/p'`

if [ -z $region ]; then
        echo "Coult not get ec2-metadata region."
        exit 1;
fi

echo "set /etc/hosts. region=$region"

DESCRIBE_COMMAND="ec2-describe-instances --region $region --show-empty-fields"
echo "$DESCRIBE_COMMAND"

listOutput=`$DESCRIBE_COMMAND`
if [ -z "$listOutput" ]; then
        echo "Could not get ec2 instances list."
        exit 1;
fi

$DESCRIBE_COMMAND | grep -v "Group" | sed -n '1i\
127.0.0.1\tlocalhost localhost.localdomain
/^INSTANCE/{
s/^[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t\([^\t]*\).*/\1/
h
}
/^TAG/{x;G;s/^\([^\n]*\)\n.*\tName\t\([^\t]*\).*/\1\t\2/p}
' | sed '/^(nil)/d' > /etc/hosts

echo "set /etc/hosts done."
cat /etc/hosts

