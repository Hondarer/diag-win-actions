#include <testfw.h>
#include "testmain2.h"

class testmain2 : public Test
{
};

TEST_F(testmain2, test)
{
    // Arrange

    // Pre-Assert

    // Act
    int result = add(1, 2); // [手順] - add(1, 2) を呼び出す。

    // Assert
    EXPECT_EQ(3, result); // [確認] - add(1, 2) の戻り値が 3 であること。
}
