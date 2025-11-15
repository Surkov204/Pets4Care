package utils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import model.Pet;
import model.PetServiceModel;

/**
 * Helper để tính giá dịch vụ dựa trên cân nặng/thể trạng thú cưng.
 */
public final class PetPricingUtils {

    private static final BigDecimal THOUSAND = new BigDecimal("1000");

    private PetPricingUtils() {
    }

    /**
     * Tính giá dịch vụ sau khi điều chỉnh theo cân nặng và loài.
     *
     * @param service  dịch vụ spa/sức khỏe
     * @param pet      thú cưng áp dụng (có thể null)
     * @return giá đã được điều chỉnh; nếu không đủ dữ liệu sẽ trả về giá gốc
     */
    public static BigDecimal calculateAdjustedPrice(PetServiceModel service, Pet pet) {
        if (service == null) {
            return BigDecimal.ZERO;
        }
        Double weight = pet != null ? pet.getWeightKg() : null;
        String species = pet != null ? pet.getSpecies() : null;
        return calculateAdjustedPrice(service.getPrice(), species, weight);
    }

    /**
     * Tính giá dịch vụ sau khi điều chỉnh theo cân nặng và loài.
     *
     * @param basePrice giá gốc trong bảng dịch vụ
     * @param species   loài thú cưng (dog/cat/...)
     * @param weightKg  cân nặng (kg)
     * @return giá đã điều chỉnh; nếu không đủ dữ liệu sẽ trả về giá gốc
     */
    public static BigDecimal calculateAdjustedPrice(BigDecimal basePrice, String species, Double weightKg) {
        if (basePrice == null || basePrice.compareTo(BigDecimal.ZERO) <= 0) {
            return basePrice;
        }
        if (weightKg == null || weightKg <= 0 || weightKg > 200) {
            return roundToNearestThousand(basePrice);
        }

        String normalizedSpecies = species != null ? species.trim().toLowerCase() : "";
        double multiplier;

        if ("dog".equals(normalizedSpecies) || "chó".equals(normalizedSpecies)) {
            if (weightKg < 7.0) {
                multiplier = 0.90;
            } else if (weightKg < 16.0) {
                multiplier = 1.00;
            } else if (weightKg <= 30.0) {
                multiplier = 1.25;
            } else {
                multiplier = 1.50;
            }
        } else if ("cat".equals(normalizedSpecies) || "mèo".equals(normalizedSpecies)) {
            if (weightKg < 4.0) {
                multiplier = 0.92;
            } else if (weightKg < 6.0) {
                multiplier = 1.00;
            } else if (weightKg < 8.0) {
                multiplier = 1.12;
            } else {
                multiplier = 1.28;
            }
        } else {
            if (weightKg < 2.0) {
                multiplier = 0.95;
            } else if (weightKg < 10.0) {
                multiplier = 1.00;
            } else if (weightKg < 25.0) {
                multiplier = 1.18;
            } else {
                multiplier = 1.35;
            }
        }

        BigDecimal adjusted = basePrice.multiply(BigDecimal.valueOf(multiplier));
        return roundToNearestThousand(adjusted);
    }

    private static BigDecimal roundToNearestThousand(BigDecimal amount) {
        if (amount == null) {
            return null;
        }
        if (amount.signum() == 0) {
            return BigDecimal.ZERO;
        }
        return amount.divide(THOUSAND, 0, RoundingMode.HALF_UP).multiply(THOUSAND);
    }
}







