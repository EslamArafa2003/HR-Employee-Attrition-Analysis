SELECT Department,COUNT(*) AS Total_Per_Department FROM dbo.HR_Employee_Attrition
WHERE Attrition = 'Yes'
GROUP BY Department
ORDER BY Total_Per_Department DESC;