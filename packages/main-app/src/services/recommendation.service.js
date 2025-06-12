class RecommendationService {
    static getRecommendation(predictionData) {
        if (!predictionData || !predictionData.prediction) {
            return { recommendation: "No prediction data available to make a recommendation." };
        }

        try {
            const values = JSON.parse(predictionData.prediction);
            const lastValue = values[values.length - 1];
            if (lastValue > 80) {
                return { recommendation: "Khuyến nghị: Tăng CPU" }; // "Recommendation: Increase CPU"
            } else if (lastValue < 20) {
                return { recommendation: "Khuyến nghị: Giảm CPU" }; // "Recommendation: Decrease CPU"
            } else {
                return { recommendation: "Tải CPU ở mức ổn định." }; // "CPU load is stable."
            }
        } catch (error) {
            console.error("Failed to parse prediction data for recommendation", error);
            return { recommendation: "Could not generate recommendation due to invalid prediction format."}
        }
    }
}
module.exports = RecommendationService; 