# Set up

library(readr)
library(rpart) # Model fitting

diet <- read_csv("D:/ML/Projects/3 diets/diet.csv", col_names = TRUE)

# Cleaning: Checking, renaming

str(diet)
names(diet) <- c("id", "gender", "age", "height",
                 "weight.i", "diet.type", "weight.f")

# Visualize

diet$weight.loss <- diet$weight.i - diet$weight.f
boxplot(weight.loss ~ diet.type, data = diet,
        main = "3 diets comparison",
        xlab = "Diet Types",
        ylab = "Weight Loss (kg)",
        col = "light gray")

abline(h = 0, col = "blue")

# Mean/Medium

groupMean <- tapply(diet$weight.loss, diet$diet.type, mean)
groupMedian <- tapply(diet$weight.loss, diet$diet.type, median)

print(groupMean)
print(groupMedian)

# 3 ANOVA

dietFisher <- aov(weight.loss ~ diet.type, data = diet)
summary(dietFisher)

dietWelch <- oneway.test(weight.loss ~ diet.type, data = diet)
print(dietWelch)

dietKruskal <- kruskal.test(weight.loss ~ diet.type, data = diet)
print(dietKruskal)

# t.test, comparison between 2 diets:
# 1:2, 1:3, 2:3

ABtt <- t.test(weight.loss ~ diet.type, var.equal = FALSE,
               data = diet[diet$diet.type != 3, ])
ACtt <- t.test(weight.loss ~ diet.type, var.equal = FALSE,
               data = diet[diet$diet.type != 2, ])
BCtt <- t.test(weight.loss ~ diet.type, var.equal = FALSE,
               data = diet[diet$diet.type != 1, ])

print(ABtt)
print(ACtt)
print(BCtt)

# Quick modeling: Repetitive partitioning (decision tree)

mse <- c()

for (i in 1:10) {
  
  test.index <- sample(79, 7)
  
  test <- diet[test.index, ]
  train <- diet[-test.index, ]
  
  fit <- rpart(weight.f ~ gender + age + height +
                 weight.i + diet.type, data = train)
  pred <- predict(fit, newdata = test)
  
  mse[i] <- mean((pred - test$weight.f)^2)
  
}

mean(mse, na.rm = TRUE)
