# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_27_170242) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bug_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_bug_reports_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.text "country"
    t.integer "country_numeric"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "designer_countries", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.bigint "designer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_designer_countries_on_country_id"
    t.index ["designer_id"], name: "index_designer_countries_on_designer_id"
  end

  create_table "designers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "creations_majeures"
    t.integer "date_deces"
    t.integer "date_naissance"
    t.text "formation_et_influences"
    t.text "heritage_et_impact"
    t.text "image"
    t.string "nom"
    t.string "prenom"
    t.text "presentation_generale"
    t.text "rejection_reason"
    t.string "slug"
    t.text "source"
    t.text "style_ou_philosophie"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "validated_by_user_id"
    t.boolean "validation", default: false
    t.index ["slug"], name: "index_designers_on_slug", unique: true
    t.index ["user_id"], name: "index_designers_on_user_id"
  end

  create_table "designers_domaines", id: false, force: :cascade do |t|
    t.bigint "designer_id", null: false
    t.bigint "domaine_id", null: false
    t.index ["designer_id"], name: "index_designers_domaines_on_designer_id"
    t.index ["domaine_id"], name: "index_designers_domaines_on_domaine_id"
  end

  create_table "designers_lists", id: false, force: :cascade do |t|
    t.bigint "designer_id", null: false
    t.bigint "list_id", null: false
    t.index ["designer_id", "list_id"], name: "index_designers_lists_on_designer_id_and_list_id"
    t.index ["list_id", "designer_id"], name: "index_designers_lists_on_list_id_and_designer_id"
  end

  create_table "designers_oeuvres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "designer_id", null: false
    t.bigint "oeuvre_id", null: false
    t.datetime "updated_at", null: false
    t.index ["designer_id", "oeuvre_id"], name: "index_designers_oeuvres_on_designer_id_and_oeuvre_id", unique: true
    t.index ["designer_id"], name: "index_designers_oeuvres_on_designer_id"
    t.index ["oeuvre_id"], name: "index_designers_oeuvres_on_oeuvre_id"
  end

  create_table "domaines", force: :cascade do |t|
    t.text "couleur"
    t.datetime "created_at", null: false
    t.text "domaine"
    t.string "svg"
    t.datetime "updated_at", null: false
  end

  create_table "etablissements", force: :cascade do |t|
    t.string "academy"
    t.string "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "messagerie"
    t.string "name"
    t.string "phone"
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "question_1"
    t.text "question_10"
    t.text "question_11"
    t.text "question_12"
    t.integer "question_2"
    t.integer "question_3"
    t.integer "question_4"
    t.integer "question_5"
    t.integer "question_6"
    t.integer "question_7"
    t.text "question_8"
    t.text "question_9"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "list_editors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "list_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["list_id"], name: "index_list_editors_on_list_id"
    t.index ["user_id"], name: "index_list_editors_on_user_id"
  end

  create_table "list_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "list_id", null: false
    t.bigint "listable_id", null: false
    t.string "listable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_items_on_list_id"
    t.index ["listable_type", "listable_id"], name: "index_list_items_on_listable"
  end

  create_table "list_visitors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "list_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["list_id"], name: "index_list_visitors_on_list_id"
    t.index ["user_id"], name: "index_list_visitors_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "previous_share_token"
    t.string "share_token"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["share_token"], name: "index_lists_on_share_token", unique: true
    t.index ["slug"], name: "index_lists_on_slug", unique: true
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "lists_oeuvres", id: false, force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "oeuvre_id", null: false
    t.index ["list_id", "oeuvre_id"], name: "index_lists_oeuvres_on_list_id_and_oeuvre_id"
    t.index ["oeuvre_id", "list_id"], name: "index_lists_oeuvres_on_oeuvre_id_and_list_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.bigint "translatable_id"
    t.string "translatable_type"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.bigint "translatable_id"
    t.string "translatable_type"
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message"
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "notions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notions_oeuvres", id: false, force: :cascade do |t|
    t.bigint "notion_id", null: false
    t.bigint "oeuvre_id", null: false
    t.index ["notion_id", "oeuvre_id"], name: "index_notions_oeuvres_on_notion_id_and_oeuvre_id", unique: true
    t.index ["notion_id"], name: "index_notions_oeuvres_on_notion_id"
    t.index ["oeuvre_id", "notion_id"], name: "index_notions_oeuvres_on_oeuvre_id_and_notion_id", unique: true
    t.index ["oeuvre_id"], name: "index_notions_oeuvres_on_oeuvre_id"
  end

  create_table "oeuvres", force: :cascade do |t|
    t.text "concept_et_inspiration"
    t.text "contexte_historique"
    t.datetime "created_at", null: false
    t.integer "date_naissance"
    t.integer "date_oeuvre"
    t.text "dimension_esthetique"
    t.text "image"
    t.text "impact_et_message"
    t.text "materiaux_et_innovations_techniques"
    t.text "nom_designer"
    t.text "nom_oeuvre"
    t.text "pays"
    t.text "presentation_generale"
    t.text "rejection_reason"
    t.string "slug"
    t.text "source"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "validated_by_user_id"
    t.boolean "validation", default: false
    t.index ["slug"], name: "index_oeuvres_on_slug", unique: true
    t.index ["user_id"], name: "index_oeuvres_on_user_id"
  end

  create_table "oeuvres_domaines", id: false, force: :cascade do |t|
    t.bigint "domaine_id", null: false
    t.bigint "oeuvre_id", null: false
    t.index ["domaine_id"], name: "index_oeuvres_domaines_on_domaine_id"
    t.index ["oeuvre_id", "domaine_id"], name: "index_oeuvres_domaines_on_oeuvre_id_and_domaine_id", unique: true
    t.index ["oeuvre_id"], name: "index_oeuvres_domaines_on_oeuvre_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "referee_id"
    t.integer "referrer_id"
    t.boolean "reward_claimed"
    t.datetime "updated_at", null: false
  end

  create_table "rejected_designers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom"
    t.string "prenom"
    t.text "reason"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_rejected_designers_on_user_id"
  end

  create_table "rejected_oeuvres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom_oeuvre"
    t.text "reason"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_rejected_oeuvres_on_user_id"
  end

  create_table "suivis", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "nb_references_emises", default: 0, null: false
    t.integer "nb_references_refusees", default: 0, null: false
    t.integer "nb_references_validees", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_suivis_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "banned"
    t.boolean "certified"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "etablissement"
    t.bigint "etablissement_id"
    t.string "firstname"
    t.string "how_did_you_hear"
    t.string "lastname"
    t.string "profile_image"
    t.string "pseudo"
    t.string "referral_code"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "rgpd_consent"
    t.string "role"
    t.string "statut"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["referral_code"], name: "index_users_on_referral_code", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bug_reports", "users"
  add_foreign_key "designer_countries", "countries"
  add_foreign_key "designer_countries", "designers"
  add_foreign_key "designers", "users"
  add_foreign_key "designers_domaines", "designers"
  add_foreign_key "designers_domaines", "domaines"
  add_foreign_key "designers_oeuvres", "designers"
  add_foreign_key "designers_oeuvres", "oeuvres"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "list_editors", "lists"
  add_foreign_key "list_editors", "users"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_visitors", "lists"
  add_foreign_key "list_visitors", "users"
  add_foreign_key "lists", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notions_oeuvres", "notions"
  add_foreign_key "notions_oeuvres", "oeuvres"
  add_foreign_key "oeuvres", "users"
  add_foreign_key "oeuvres_domaines", "domaines"
  add_foreign_key "oeuvres_domaines", "oeuvres"
  add_foreign_key "rejected_designers", "users"
  add_foreign_key "rejected_oeuvres", "users"
  add_foreign_key "suivis", "users"
end
