package sh.cliq.backend.user.validator

import jakarta.validation.ConstraintValidator
import jakarta.validation.ConstraintValidatorContext
import sh.cliq.backend.user.UserRepository

class EmailOccupiedValidator(private val userRepository: UserRepository) :
    ConstraintValidator<EmailOccupiedConstraint, String> {
    override fun isValid(value: String?, context: ConstraintValidatorContext?): Boolean {
        if (value.isNullOrEmpty()) {
            return true
        }

        return !userRepository.existsByEmail(value)
    }
}
