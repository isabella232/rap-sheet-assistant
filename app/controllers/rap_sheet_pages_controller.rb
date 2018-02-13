class RapSheetPagesController < ApplicationController
  def create
    rap_sheet = RapSheet.find(rap_sheet_page_params[:rap_sheet_id])

    RapSheetPage.scan_and_create(
      image: rap_sheet_page_params[:rap_sheet_page_image],
      rap_sheet: rap_sheet
    )

    redirect_to edit_rap_sheet_path(rap_sheet)
  end

  private

  def rap_sheet_page_params
    params.require(:rap_sheet_page)
  end
end
